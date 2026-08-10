const exploreButton =
    document.getElementById("exploreButton");

const terminalBody =
    document.getElementById("terminalBody");

const progressBar =
    document.getElementById("progressBar");

const progressText =
    document.getElementById("progressText");

const statusTitle =
    document.getElementById("statusTitle");

const statusText =
    document.getElementById("statusText");

const statusIcon =
    document.getElementById("statusIcon");

const themeButton =
    document.getElementById("themeButton");

const factButton =
    document.getElementById("factButton");

const factText =
    document.getElementById("factText");


/* =========================
   TERRAFORM DEPLOYMENT
========================= */

const deploymentSteps = [

    "terraform init",

    "Initializing the AWS provider...",

    "terraform plan",

    "Checking infrastructure changes...",

    "Creating random_id.server_suffix...",

    "Creating aws_instance.mywebserver01...",

    "Configuring EC2 instance...",

    "Applying infrastructure changes...",

    "Terraform apply complete!",

    "🚀 Infrastructure deployed successfully!"

];


exploreButton.addEventListener(
    "click",
    function () {

        exploreButton.disabled = true;

        exploreButton.textContent =
            "⚙️ Deploying...";

        terminalBody.innerHTML = "";

        let step = 0;

        let progress = 0;


        statusTitle.textContent =
            "Deployment in Progress";

        statusText.textContent =
            "Terraform is provisioning the infrastructure...";

        statusIcon.textContent =
            "⚙️";


        const interval = setInterval(
            function () {

                if (step < deploymentSteps.length) {

                    const line =
                        document.createElement("p");

                    line.innerHTML =
                        `<span class="prompt">$</span> ${deploymentSteps[step]}`;

                    terminalBody.appendChild(line);

                    terminalBody.scrollTop =
                        terminalBody.scrollHeight;


                    step++;


                    progress =
                        Math.min(
                            100,
                            Math.round(
                                (step /
                                    deploymentSteps.length) *
                                100
                            )
                        );


                    progressBar.style.width =
                        progress + "%";

                    progressText.textContent =
                        progress + "%";

                } else {

                    clearInterval(interval);


                    statusTitle.textContent =
                        "Infrastructure Deployed Successfully!";

                    statusText.textContent =
                        "Your Terraform deployment simulation is complete. 🚀";

                    statusIcon.textContent =
                        "🚀";


                    exploreButton.disabled =
                        false;

                    exploreButton.textContent =
                        "🔄 Deploy Again";

                }

            },
            700
        );

    }
);


/* =========================
   DARK MODE
========================= */

themeButton.addEventListener(
    "click",
    function () {

        document.body.classList.toggle("dark");


        if (
            document.body.classList.contains("dark")
        ) {

            themeButton.textContent =
                "☀️ Light Mode";

        } else {

            themeButton.textContent =
                "🌙 Dark Mode";

        }

    }
);


/* =========================
   TERRAFORM FACTS
========================= */

const facts = [

    "Terraform uses a state file to remember the infrastructure it manages.",

    "Terraform can automatically determine dependencies between resources.",

    "Terraform providers translate Terraform configuration into API calls.",

    "terraform plan shows what Terraform intends to change before applying it.",

    "Terraform can manage infrastructure across multiple cloud providers.",

    "Resources in Terraform are identified using addresses such as aws_instance.mywebserver01."

];


let factIndex = 0;


factButton.addEventListener(
    "click",
    function () {

        factIndex++;


        if (factIndex >= facts.length) {
            factIndex = 0;
        }


        factText.textContent =
            facts[factIndex];

    }
);