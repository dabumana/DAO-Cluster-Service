import * as anchor from '@project-serum/anchor';
import { Program } from '@project-serum/anchor';
import { DaoApp } from '../target/types/dao_app';

describe('dao_app', () => {

  // Configure the client to use the local cluster.
  anchor.setProvider(anchor.Provider.env());

  const program = anchor.workspace.DaoApp as Program<DaoApp>;

  it('Is initialized!', async () => {
    // Add your test here.
    const tx = await program.rpc.initialize({});
    console.log("Your transaction signature", tx);
  });
});
