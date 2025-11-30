enum SyncTrigger {
  appLaunch,
  manual,
  background,
  networkRestore,
  dataChange
}

enum ConflictResolution {
  serverWins,
  clientWins,
  lastWriteWins,
  manual
}
