  echo "apiVersion: kustomize.config.k8s.io/v1beta1"            >  ./yml-Files/kustomization.yml
  echo "kind: Kustomization"                                    >> ./yml-Files/kustomization.yml
  echo "resources:"                                             >> ./yml-Files/kustomization.yml
  echo "  - deployment.yml"                                     >> ./yml-Files/kustomization.yml
  echo "  - service.yml"                                        >> ./yml-Files/kustomization.yml
  echo "  - ingress.yml"                                        >> ./yml-Files/kustomization.yml
  echo "images:"                                                >> ./yml-Files/kustomization.yml
  echo "  - name: nodejs"                                   >> ./yml-Files/kustomization.yml
  echo "    newName: devops2022.azurecr.io/${1}"                >> ./yml-Files/kustomization.yml
  echo "    newTag: ${2}"                                       >> ./yml-Files/kustomization.yml
