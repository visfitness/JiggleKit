# Documentation

To generate the `DocC` folder, use the following command (assuming XCode is installed):

```bash
 xcodebuild clean docbuild -scheme JiggleKit -destination generic/platform=IOS DOCC_HOSTING_BASE_PATH=JiggleKit OTHER_DOCC_FLAGS="--output-path Documentation/DocC"
```
