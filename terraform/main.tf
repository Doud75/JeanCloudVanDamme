terraform {
  backend "s3" {
    bucket = "jean-cloud-terraform-state"
    key    = "state.json"
    region = "eu-west-3"
    dynamodb_table = "jean-cloud-state-lock"
  }
}

# ici je crée un bucket dans lequel on va stocker le state,
# et un dynamodb table pour le sauver du state lock
# ca va permettre de bloquer l'acces au state si quelqu'un d'autre est en train de le modifier
#et aussi on aura tous la possibilité de travailler sur le meme state sans conflitsaws dynamodb create-table \


