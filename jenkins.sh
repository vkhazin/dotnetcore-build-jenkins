# Install using deb packages:
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y
echo "Pausing for a bit to let Jenkins service start..."
sleep 10 # jenkins-cli download fails otherwise

# Install required plug-ins:
JENKINS_URL="http://127.0.0.1:8080/"
USERNAME="admin"
PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
curl $JENKINS_URL/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar
java -jar jenkins-cli.jar -s $JENKINS_URL install-plugin dashboard-view --username "$USERNAME" --password "$PASSWORD"
# Required for Bitbucket webhook
java -jar jenkins-cli.jar -s $JENKINS_URL install-plugin bitbucket --username "$USERNAME" --password "$PASSWORD"
# Required for using Aws Credentials
java -jar jenkins-cli.jar -s $JENKINS_URL install-plugin aws-credentials --username "$USERNAME" --password "$PASSWORD"
# Required for using custom build container
java -jar jenkins-cli.jar -s $JENKINS_URL install-plugin docker-custom-build-environment --username "$USERNAME" --password "$PASSWORD"

# Grant docker permissions to Jenkins user
sudo groupadd docker
sudo usermod -a -G docker jenkins
sudo service docker restart
sudo service jenkins restart

PUBLIC_IP=$(curl ipinfo.io/ip)
echo "Login into Jenkins: https://$PUBLIC_IP, using password: $PASSWORD, ignore certificate warning, and skip setup!"