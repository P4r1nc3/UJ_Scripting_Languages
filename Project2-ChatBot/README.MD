# ChatBot Setup and Execution Guide

This guide will walk you through the process of setting up and running a chatbot using Rasa and Discord integration.

### Training the Bot

1. Open a terminal and navigate to your project directory.
2. Train the bot using the following command:

```rasa train```

### Running the Bot

1. Open three separate terminals.
2. In the first terminal, run the Rasa server:

```bash
rasa run
```

3. In  the second terminal, run the Rasa actions server:

```bash
rasa run actions
```

4. In the third terminal, run the Discord integration script:

```bash
python3 discord_config.py
```