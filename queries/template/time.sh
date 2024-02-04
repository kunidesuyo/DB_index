echo "no index"
time(cat /queries/template/select.sql | mysql -uuser -ppassword db > /dev/null)
echo -e "\n"

echo "using index"
time(cat /queries/template/select_using_index.sql | mysql -uuser -ppassword db > /dev/null)