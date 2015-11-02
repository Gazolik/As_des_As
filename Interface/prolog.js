var finAction1 = false;
var finAction2 = false;
// ----------------------------------------  Appelle prolog et callback
//Appeller par prolog
function updatePlane(param)
{
	avion1.modifierVie(param.avion1.v);
	avion2.modifierVie(param.avion2.v);	

	console.debug(param.move1);
	console.debug(param.move2);

	console.debug((param.avion1.x+1) + ' ' + (param.avion1.y+1) + ' ' + param.avion1.d);
	console.debug((param.avion2.x+1) + ' ' + (param.avion2.y+1) + ' ' +param.avion2.d);

	if(param.move1 === undefined)
	{
		avion1.positionner((param.avion1.x+1), (param.avion1.y+1), param.avion1.d);
		avion2.positionner((param.avion2.x+1), (param.avion2.y+1), param.avion2.d);
	}
	else
	{
		var move1 = param.move1.substring(1, (param.move1.length -1)).split(',');
		var move2 = param.move2.substring(1, (param.move2.length -1)).split(',');

		avion1.deplacer(move1[0]).then(function(){
			avion1.tentativeDeTir(avion2);
			testFinJeux();
			avion1.deplacer(move1[1]).then(function(){
				avion1.tentativeDeTir(avion2);
				testFinJeux();
				avion1.deplacer(move1[2]).then(function(){
					avion1.tentativeDeTir(avion2);
					testFinJeux();
					timeout = setTimeout(function()
					{
						finAction1 =true;
						if(finAction1 && finAction2)
						{
							avion1.positionner((param.avion1.x+1), (param.avion1.y+1), param.avion1.d);
							avion2.positionner((param.avion2.x+1), (param.avion2.y+1), param.avion2.d);
							finAction1 = false;
							finAction2 = false;
						}
					}, 1000);
					
				});
			});
		}); 
		
		avion2.deplacer(move2[0]).then(function(){
			avion2.tentativeDeTir(avion1);
			testFinJeux();
			avion2.deplacer(move2[1]).then(function(){
				avion2.tentativeDeTir(avion1);
				testFinJeux();
				avion2.deplacer(move2[2]).then(function(){
					avion2.tentativeDeTir(avion1);
					testFinJeux();
					timeout = setTimeout(function()
					{
						finAction2 =true;
						if(finAction1 && finAction2)
						{
							avion1.positionner((param.avion1.x+1), (param.avion1.y+1), param.avion1.d);
							avion2.positionner((param.avion2.x+1), (param.avion2.y+1), param.avion2.d);
							finAction1 = false;
							finAction2 = false;
						}
					}, 1000);
				})
			});
		}); 
		
		//TODO à effacer quand tous fonctionnera
		/*timeout = setTimeout(function()
		{
			avion1.positionner((param.avion1.x+1), (param.avion1.y+1), param.avion1.d);
			avion2.positionner((param.avion2.x+1), (param.avion2.y+1), param.avion2.d);
		}, 3000);*/
	}

	
}

function testFinJeux()
{
	if(avion1.vie <= 0 || avion2.vie <= 0 || (avion1.x === avion2.x && avion1.y === avion2.y))
	{
		score2 += (avion1.vie <= 0)?1:0;
		score1 += (avion2.vie <= 0)?1:0;

		$("#score1").text(score1);
		$("#score2").text(score2);

		clearInterval(interval);
		
		timeout = setTimeout(function()
		{
			openPopUp("popupScore");
		}, 1000);
	}
}

//Function appellant le prolog. Le callback est sur planeState
function initPlaneProlog()
{
	$.ajax({
		url: "http://localhost:8000/initPlane",
		type: "GET",
		dataType: "jsonp",
		success: function (data) {
			data;
		}
	});
}

function nextProlog()
{
	$.ajax({
		url: "http://localhost:8000/next",
		type: "GET",
		dataType: "jsonp",
		success: function (data) {
			data;
		}, 
		error: function(e)
		{
			//On passe bisarement dans erreur même quand on a un http 200
			if(e.status != 200)
				clearInterval(interval);
		}
	});
}

//Fonction appellant le prolog. Le callback est sur planeState
function appelerPrologWithParam(tab)
{
	$.ajax({
		url: "http://localhost:8000/nextPlayer",
		type: "POST",
		dataType: "jsonp",
		data : {act1 : tab[0], act2 : tab[1], act3 : tab[2]},
		success: function (data) {
			data;
		}, 
		error: function(e)
		{
			//On passe bisarement dans erreur même quand on a un http 200
			if(e.status != 200)
				clearInterval(interval);
		}
	});
}
