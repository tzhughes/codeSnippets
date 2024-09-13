{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Traceback (most recent call last):\n",
       "  File \"/Users/timothyh/.vscode/extensions/ms-python.python-2024.14.0-darwin-x64/python_files/python_server.py\", line 130, in exec_user_input\n",
       "    retval = callable_(user_input, user_globals)\n",
       "  File \"<string>\", line 1, in <module>\n",
       "ModuleNotFoundError: No module named 'pandas'\n",
       "\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "import pandas as pd\n",
    "# Create a DataFrame with the required data\n",
    "\n",
    "data = {\n",
    "    'name': ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],\n",
    "    'age': [25, 30, 35, 40, 45],\n",
    "    'city': ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix']\n",
    "}\n",
    "\n",
    "print(data)\n",
    "df = pd.DataFrame(data)\n",
    "# Save the DataFrame to a tab-separated file\n",
    "\n",
    "df.to_csv('data.tsv', sep='\\t', index=False)\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Hello World\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "print(\"Hello World\")\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Hello World\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "print(\"Hello World\")\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Hello World\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "print(\"Hello World\")\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Hello Worlde\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "print(\"Hello Worlde\")\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Traceback (most recent call last):\n",
       "  File \"/Users/timothyh/.vscode/extensions/ms-python.python-2024.14.0-darwin-x64/python_files/python_server.py\", line 130, in exec_user_input\n",
       "    retval = callable_(user_input, user_globals)\n",
       "  File \"<string>\", line 1, in <module>\n",
       "ModuleNotFoundError: No module named 'pandas'\n",
       "\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "import pandas as pd\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Traceback (most recent call last):\n",
       "  File \"/Users/timothyh/.vscode/extensions/ms-python.python-2024.14.0-darwin-x64/python_files/python_server.py\", line 130, in exec_user_input\n",
       "    retval = callable_(user_input, user_globals)\n",
       "  File \"<string>\", line 1, in <module>\n",
       "ModuleNotFoundError: No module named 'pandas'\n",
       "\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "import pandas as pd\n",
    "print(\"Hello Worlde\")\n"
   ]
  }
 ],
 "metadata": {
  "language_info": {
   "name": "python"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 2
}
