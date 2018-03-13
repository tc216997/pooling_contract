module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      mnemonic:'candy maple cake sugar pudding cream honey rich smooth crumble sweet treat',
      total_accounts: 10,
      network_id: '*'
    }
  }  
};
