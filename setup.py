from setuptools import setup

setup(
    name="SystemInfoCollector",
    version="1.0",
    description="Collects system information for esports configuration survey",
    author="Your Name",
    author_email="your.email@example.com",
    install_requires=[
        'psutil',
        'wmi',
        'GPUtil',
        'screeninfo',
        'pywin32'
    ],
)