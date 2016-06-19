app = angular.module 'app', []

app.controller 'ctrl', ['$scope', '$sce', 'API', ($scope, $sce, API) ->

	sanitizer = (str) ->
		str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;')

	$scope.parse = () ->
		content = $scope.content
		API.reserve_request content, (text) ->
			console.log text
			text = text.map (val) ->
				if typeof val == 'string'
					sanitizer val
				else
					org = sanitizer(val[0])
					yomi = sanitizer(val[1])
					"<ruby><rb>#{org}</rb><rp>(</rp><rt>#{yomi}</rt><rp>)</rp></ruby>"
			text = text.reduce (prev, current) ->
				prev + current
			$scope.parsed = $sce.trustAsHtml(text)
]

app.service 'API', ['$timeout', '$http', ($timeout, $http) ->

	timer = null

	@reserve_request = (text, callback) ->
		$timeout.cancel timer if timer
		timer = $timeout () ->
			$http.post '/convert', {text: text}
				.success (data) ->
					callback(data)
				.error (data, status, headers, config) ->
					console.log data
					console.log status
					console.log headers
					console.log config
		, 2000
		
	null
]