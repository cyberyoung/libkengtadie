echo "Downed server test, setting up.."
# set up downed server
head -n `wc -l ./kengtadie.servers | awk '{print $1-1}'` ./kengtadie.servers > ./kengtadie.servers.minus.one
DOWNEDSERVER=`tail -n 1 ./kengtadie.servers | awk '{print $1}'`
# set up new server
NEWSERVER=999.999.999:11211
cp ./kengtadie.servers ./kengtadie.servers.plus.one
echo -e "8\t${NEWSERVER}\t300" >> ./kengtadie.servers.plus.one

echo "  Running on original set of servers to get baseline"
touch -m ./kengtadie.servers # make sure we're working with the current version
./ketama_test ./kengtadie.servers > original_mapping

NUMORIGITEMS=`wc -l original_mapping | awk '{print $1}'`

echo "  Running on original set of servers minus one"
./ketama_test ./kengtadie.servers.minus.one > minus_one_mapping

echo -n "  Analyzing results..."
MINUS_ONE_MOVED_ITEMS=`diff -y --suppress-common-lines original_mapping minus_one_mapping | grep -c -v "${DOWNEDSERVER}"`


if [ ${MINUS_ONE_MOVED_ITEMS} = 0 ]
then
  echo "OK no items disturbed"
else
  PC=$(( $MINUS_ONE_MOVED_ITEMS * 100 / $NUMORIGITEMS ))
  echo "WARNING ${MINUS_ONE_MOVED_ITEMS} items disturbed ($PC%)"
fi

echo "  Running on original set of servers plus one"
./ketama_test ./kengtadie.servers.plus.one > plus_one_mapping

echo -n "  Analyzing results..."
PLUS_ONE_MOVED_ITEMS=`diff -y --suppress-common-lines original_mapping plus_one_mapping | grep -c -v "${NEWSERVER}"`

if [ ${PLUS_ONE_MOVED_ITEMS} = 0 ]
then
  echo "OK no items disturbed"
else
  PC=$(( $PLUS_ONE_MOVED_ITEMS * 100 / $NUMORIGITEMS ))
  echo "WARNING ${PLUS_ONE_MOVED_ITEMS} items disturbed ($PC%)"
fi

rm -rf ./kengtadie.servers.minus.one ./kengtadie.servers.plus.one original_mapping minus_one_mapping plus_one_mapping
echo "Finished downed server test."
