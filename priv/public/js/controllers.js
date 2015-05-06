var app = angular.module('reconliveApp', ['ui.bootstrap']);

app.factory('reconliveHomePageService', function ($http) {
	return {
		
		getTopTechnologyNews: function (count, skip) {
			return $http.get('/api/news/topnews?c=us_technology&n=' + count + '&s=' + skip).then(function (result) {
				return result.data.articles;
			});
		},
		getTopScienceNews: function (count, skip) {
			return $http.get('/api/news/topnews?c=us_science&n=' + count + '&s=' + skip).then(function (result) {
				return result.data.articles;
			});
		},
		getTopInternetNews: function (count, skip) {
			return $http.get('/api/news/topnews?c=us_internet&n=' + count + '&s=' + skip).then(function (result) {
				return result.data.articles;
			});
		},		

	};
});
app.controller('ReconliveHome', function ($scope, reconliveHomePageService) {
	//the clean and simple way
	$scope.currentYear = (new Date).getFullYear();
	$scope.topTechnologyNews = reconliveHomePageService.getTopTechnologyNews(5,0);
	$scope.topInternetNews   = reconliveHomePageService.getTopInternetNews(5,0);
	$scope.topScienceNews    = reconliveHomePageService.getTopScienceNews(5,0);
});

