import os.path
import sys
import pickle
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.http import MediaFileUpload

# If modifying these scopes, delete the file token.pickle.
SCOPES = ['https://www.googleapis.com/auth/drive.file']

# Folder name in Google Drive to store all manuscripts
BOOK_FOLDER_NAME = "The Invisible Pattern - Manuscripts"

def get_service():
    """Shows basic usage of the Drive v3 API.
    Prints the names and ids of the first 10 files the user has access to.
    """
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    token_path = 'scripts/token.pickle'
    creds_path = 'scripts/credentials.json'

    # Adjust paths if running from root
    if not os.path.exists('scripts'):
       # Maybe running from scripts dir?
       if os.path.exists('token.pickle'):
           token_path = 'token.pickle'
           creds_path = 'credentials.json'
    
    if os.path.exists(token_path):
        with open(token_path, 'rb') as token:
            creds = pickle.load(token)
            
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not os.path.exists(creds_path):
                print(f"Error: {creds_path} not found.")
                print("1. Go to Google Cloud Console.")
                print("2. Create a project and enable Google Drive API.")
                print("3. Create OAuth 2.0 Client credentials (Desktop App).")
                print(f"4. Download JSON and save as '{creds_path}'.")
                return None
            
            flow = InstalledAppFlow.from_client_secrets_file(
                creds_path, SCOPES)
            creds = flow.run_local_server(port=0)
            
        # Save the credentials for the next run
        with open(token_path, 'wb') as token:
            pickle.dump(creds, token)

    return build('drive', 'v3', credentials=creds)


def get_or_create_folder(service, folder_name):
    """Get the folder ID, or create it if it doesn't exist."""
    # Search for existing folder
    query = f"name='{folder_name}' and mimeType='application/vnd.google-apps.folder' and trashed=false"
    results = service.files().list(q=query, spaces='drive', fields='files(id, name)').execute()
    folders = results.get('files', [])
    
    if folders:
        return folders[0]['id']
    
    # Create folder if not found
    folder_metadata = {
        'name': folder_name,
        'mimeType': 'application/vnd.google-apps.folder'
    }
    folder = service.files().create(body=folder_metadata, fields='id').execute()
    print(f"Created folder: {folder_name}")
    return folder.get('id')


def find_existing_file(service, file_name, folder_id):
    """Search for an existing file by name in the specified folder."""
    query = f"name='{file_name}' and '{folder_id}' in parents and trashed=false"
    results = service.files().list(q=query, spaces='drive', fields='files(id, name)').execute()
    files = results.get('files', [])
    
    if files:
        return files[0]['id']
    return None


def upload_file(file_path):
    service = get_service()
    if not service:
        return

    filename = os.path.basename(file_path)
    file_name_without_ext = os.path.splitext(filename)[0]

    print(f"Uploading {filename} to Google Drive and converting to Docs...")

    # Get or create the book folder
    folder_id = get_or_create_folder(service, BOOK_FOLDER_NAME)

    # Determine source mime type
    mime_type = 'application/octet-stream'
    if filename.lower().endswith('.pdf'):
        mime_type = 'application/pdf'
    elif filename.lower().endswith('.html'):
        mime_type = 'text/html'
    elif filename.lower().endswith('.md'):
        mime_type = 'text/plain'
    elif filename.lower().endswith('.docx'):
        mime_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'

    # Check if file with same name already exists in folder
    existing_file_id = find_existing_file(service, file_name_without_ext, folder_id)
    
    media = MediaFileUpload(file_path,
                            mimetype=mime_type,
                            resumable=True)
    
    try:
        if existing_file_id:
            # Update existing file
            print(f"Found existing doc, updating...")
            file = service.files().update(
                fileId=existing_file_id,
                media_body=media,
                fields='id, webViewLink'
            ).execute()
            print(f"Updated! File ID: {file.get('id')}")
        else:
            # Create new file in the book folder
            file_metadata = {
                'name': file_name_without_ext,
                'mimeType': 'application/vnd.google-apps.document',
                'parents': [folder_id]
            }
            file = service.files().create(
                body=file_metadata,
                media_body=media,
                fields='id, webViewLink'
            ).execute()
            print(f"Created! File ID: {file.get('id')}")
        
        print(f"Link: {file.get('webViewLink')}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python upload_to_gdocs.py <path_to_pdf>")
        sys.exit(1)
        
    file_path = sys.argv[1]
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        sys.exit(1)
        
    upload_file(file_path)
