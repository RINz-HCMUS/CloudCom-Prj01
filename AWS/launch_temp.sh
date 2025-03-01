# Cập nhật hệ thống
sudo apt update -y
sudo apt upgrade -y

# Cài đặt Python 3 và pip
sudo apt install python3 python3-pip -y

# Cài đặt thư viện MySQL cho Python
pip3 install pymysql

# Cài đặt Git
sudo apt install git -y

# Cài đặt môi trường  ao
sudo apt install python3-venv -y
python3 -m venv myvenv
source myvenv/bin/activate

# cài đặt thư viện flask
pip install flask flask-cors gunicorn

# clone git
git clone https://github.com/RINz-HCMUS/CloudCom-Prj01.git /home/ubuntu/task-manager

# Di chuyển den thư muc chứa app.py (backend)
ls -l /home/ubuntu/task-manager
cd /home/ubuntu/task-manager/AWS

# Tạo file .env với nội dung cần thiết
cat <<EOF > /home/ubuntu/.env
S3_BUCKET_URL="YOUR_S3_URL"
DB_HOST="YOUR_RDS_URL"
DB_USER=admin
DB_PASS="YOUR_PASSWORD"
DB_NAME=TaskManager
EOF
sudo chown ubuntu:ubuntu /home/ubuntu/.env
sudo chmod 600 /home/ubuntu/.env


# Chạy backend
python3 app.py
