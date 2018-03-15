A pretty common pooling contract. Contract stores how many eth an address has sent, and distribute the tokens at a rate that proportional to the amount of eth the pool participant has sent minus the 1.5% fee. This is just a hobby project and have not been tested on a live network. I am not responsible for any type of fund loss or contract vulnerability!

warning: This is NOT a trustless contract. This contract also haven't been unit tested yet! Use at your own risk!
This contract has
1) a one-time function that allows designated wallet to set an address that the funds can be sent to.
2) a one-time function that allows designated wallet to set the token address
3) an emergency one-time function that allows the setting of a new wallet address in case the original
   designated wallet is compromised.
4) a one-time withdraw function that allows designated wallet to collect the contract fee which is 1.5% of 
   total eth pooled.
5) a one-time function to send the funds to the address that have been set to.
6) a refund function that pool participants can call if the funds have not been sent out yet.
7) a withdraw function that pool partipants can call when the tokens have been deposited.