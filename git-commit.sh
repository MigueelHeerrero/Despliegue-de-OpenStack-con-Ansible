./git-vars.sh
echo "Introduce el mensaje que se incluirá en el commit:"
read RESPUESTA
git commit -m "$RESPUESTA"
