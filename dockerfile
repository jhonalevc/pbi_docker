# Use an official PowerShell image as a parent image
FROM mcr.microsoft.com/powershell:nanoserver-1909

# Expose port 8080 for the web portal
EXPOSE 9898

# Set the working directory to the root of the container
WORKDIR /

# Download and install Power BI Report Server
RUN Invoke-WebRequest -Uri "https://download.microsoft.com/download/4/8/7/4874aa71-d4ec-4a65-b17c-43b08dc2b2a4/PBIRS_2020_March.exe" -OutFile "PBIRS.exe" && \
    Start-Process -Wait -FilePath .\PBIRS.exe -ArgumentList '/install /quiet /norestart' && \
    Remove-Item PBIRS.exe -Force

# Copy the PBIX file of the Power BI report to the container
COPY Current_Report.pbix /

# Start the Power BI Report Server Windows service
CMD Start-Service 'PBIRS' ; \
    Set-Service -Name 'PBIRS' -StartupType 'Automatic' ; \
    Set-PBIDataSource -Name 'MyDataSource' -ConnectionString 'Server=MyServer;Database=MyDatabase;Trusted_Connection=True;' ; \
    Set-PBIReportServerWebConfig -MaxRequestLength 102400 ; \
    Publish-PBIReport -Path 'C:\Current_Report.pbix' -Name 'MyReport' -OverwriteIfExists -SkipDataModelUpgrade
