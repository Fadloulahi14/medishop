# Justification des ports

- Front SG : 80/TCP et 443/TCP depuis Internet ; 22/TCP uniquement depuis l'IP publique de l'administrateur.
- Back SG : 3000/TCP uniquement depuis le Security Group Front ; 22/TCP uniquement depuis le Front pour le bastion.
- DB SG : 5432/TCP uniquement depuis le Security Group Back ; 22/TCP uniquement depuis le Front pour l'administration.
- Aucun port Back ou DB n'est exposé directement à Internet.
