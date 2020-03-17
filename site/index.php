<html>
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title>Олег</title>
 <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">

 </head>
 <body>
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    <a class="navbar-brand" href="http://o1eg.pp.ua">CI/CD pipeline for web app</a>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav">
      </ul>
    </div>
  </nav>
  <br>
  <br>
  <br>
     <div class="container">
     <div class="row">
      <div class="col-8">
       <br>
       <br>
       <br>
       <br>
       <h1 class="display-4">Hello! I’m Oleg! :))))))</h1>
       <hr>
       <span class="subtitle">This is my site for project at EPAM University Program</span>
       <p class="excerpt">IP: 

<?php
$eip = file_get_contents('http://169.254.169.254/latest/meta-data/public-ipv4');
echo $eip
?>

</p>
 </div>
      <div class="col-4">
<img src="https://roztorguiev-site.s3.us-east-2.amazonaws.com/1.jpg" class="rounded float-left" alt="OLEG">
      </div>
     </div>
     <br><br><br><hr>
          <div class="row float-right">
        <div class="col" >
<p> <a href="https://github.com/o1egr/project_site" class="text-dark">GitHub</a></p>
      </div>
        <div class="col">
<p> <a href="http://3.15.154.101:8080" class="text-dark">Jenkins</a></p>
      </div>
        <div class="col">
<p><a href="https://console.aws.amazon.com/console/" class="text-dark">AWS</a></p>
      </div>
      </div>
    </div>
 </body>
</html>
