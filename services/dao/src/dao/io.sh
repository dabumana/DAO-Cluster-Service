anchor build
anchor deploy
echo ./target/idl/dao_app.json >> ./app/src/idl.json
cd app
npm start