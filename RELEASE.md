# Instructions for release Horizon Wallet

1. web release
  a. make sure to update manifest.json version
  b. udpate tag version in config
  c. merge into main
  d. tag release + push tag to github

2. extension release
 a. make sure variables are set properly
 b. run build_release.sh
   - (optional) ensure extension works
 c.  tar -czvf horizon_wallet_extension_chrome-[first-6-of-commit-sha || version ( perhaps better )].tar.gz  build/web

 3. upload to chrome store

 4. update env variable in version service (update max version)


