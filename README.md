# tkr-customizer

Utilities to help find, download, and customize TKR and TKG BOM files.

## Listing Available BOM Version Tags

Get help.

```bash
./hack/list-bom.sh --help
```

List all available versions of the production TKR BOMs.

```bash
./hack/list-bom.sh --product tkr
```

List all available versions of the production TKG BOMs.

```bash
./hack/list-bom.sh --product tkg
```

List all available versions of the staging TKG BOMs.

```bash
./hack/list-bom.sh --product tkg --staging
```

## Printing a BOM

Get help.

```bash
./hack/get-bom.sh --help
```

Print the BOM of TKG production version v1.3.1-patch1 to stdout.

```bash
./hack/get-bom.sh --product tkg --tag v1.3.1-patch1
```

Print the BOM of TKR staging version v1.21.1_vmware.4-tkg.1-zshippable to stdout.

```bash
./hack/get-bom.sh --product tkr --tag v1.21.1_vmware.4-tkg.1-zshippable --staging
```

## Replacing a Component within a BOM

Get help.

```bash
./hack/replace-component.sh --help
```

Fully replace a component definition within a BOM file and print the edited BOM.

```bash
./hack/replace-component.sh --component kubernetes-sigs_kind --value '
  - version: v1.21.1+vmware.my-custom-version
    images:
      kindNodeImage:
        imagePath: kind/node
        imageRepository: projects.registry.vmware.com/sample
        tag: v1.21.1_vmware.my-custom-version
' < /tmp/downloaded-bom.yaml
```

## Patching a Component's Image within a BOM

Get help.

```bash
./hack/patch-component-image.sh --help
```

Perform a patch edit to a component's image and print the edited BOM to stdout.

```bash
./hack/patch-component-image.sh --component tanzu_core_addons --image kappControllerTemplatesImage --value '
  imageRepository: my-custom-registry.example.com
  tag: v1.0.1-custom
' < /tmp/downloaded-bom.yaml
```

## Patching a Top-Level Key within a BOM

Get help.

```bash
./hack/patch-top-level-key.sh --help
```

Perform a patch edit to the value of a top-level key and save the edited BOM to a file called `my-bom.yaml`.

```bash
./hack/patch-top-level-key.sh --key 'tkr-bom' --value '
  imageRepository: my-custom-registry.example.com
' < /tmp/downloaded-bom.yaml > my-bom.yaml
```

## Pushing a BOM

Get help.

```bash
./hack/push-bom.sh --help
```

Read the BOM YAML from stdin and push it as a container image to the specified destination.

```bash
./hack/push-bom.sh --destination gcr.io/my-project/my-repository:my-tag < /tmp/my-bom.yaml
```

## Examples of Combining the Above Examples using a Shell Pipeline

Get the latest production TKR BOM,
replace the `kubernetes-sigs_kind` image,
patch-edit the kappControllerTemplatesImage image,
and push the resulting BOM as a container image.

```bash
./hack/get-bom.sh --product tkr --tag $(./hack/list-bom.sh --product tkr | tail -1) \
  | ./hack/replace-component.sh --component kubernetes-sigs_kind --value '
  - version: v1.21.1+vmware.my-custom-version
    images:
      kindNodeImage:
        imagePath: kind/node
        imageRepository: my-custom-registry.example.com
        tag: v1.21.1_vmware.my-custom-version
  ' \
  | ./hack/patch-component-image.sh --component tanzu_core_addons --image kappControllerTemplatesImage --value '
  imageRepository: my-custom-registry.example.com
  ' \
  | ./hack/push-bom.sh --destination gcr.io/my-repository:my-tag
```

Same thing as above, but this time read the new YAML values from files.

```bash
cat <<EOF >/tmp/my-kind.yaml
  - version: v1.21.1+vmware.my-custom-version
    images:
      kindNodeImage:
        imagePath: kind/node
        imageRepository: my-custom-registry.example.com
        tag: v1.21.1_vmware.my-custom-version
EOF

cat <<EOF >/tmp/patch-kappControllerTemplatesImage.yaml
  imageRepository: my-custom-registry.example.com
EOF

./hack/get-bom.sh --product tkr --tag $(./hack/list-bom.sh --product tkr | tail -1) \
  | ./hack/replace-component.sh --component kubernetes-sigs_kind --value-file /tmp/my-kind.yaml \
  | ./hack/patch-component-image.sh --component tanzu_core_addons --image kappControllerTemplatesImage --value-file /tmp/patch-kappControllerTemplatesImage.yaml \
  | ./hack/push-bom.sh --destination gcr.io/my-repository:my-tag
```
