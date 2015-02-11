module = angular.module("makerscience.profile.controllers", ['makerscience.profile.services', 'commons.accounts.services'])

module.controller("MakerScienceProfileListCtrl", ($scope, MakerScienceProfile) ->
    $scope.init = (limit) ->
        params = {}
        if limit
            params['limit'] = limit
        $scope.profiles = MakerScienceProfile.getList(params).$object
)

module.controller("MakerScienceProfileCtrl", ($scope, $stateParams, MakerScienceProfile, MakerScienceProject, MakerScienceResource, MakerScienceProfileTaggedItem, PostalAddress) ->

    MakerScienceProfile.one($stateParams.id).get().then((makerscienceProfileResult) ->
        $scope.profile = makerscienceProfileResult

        $scope.preparedInterestTags = []
        $scope.preparedSkillTags = []

        $scope.member_projects = []
        $scope.member_resources = []

        angular.forEach($scope.profile.teams, (team) ->
            MakerScienceProject.one().get({parent__id : getObjectIdFromURI(team.project)}).then((makerscienceProjectResults) ->
                if makerscienceProjectResults.objects.length == 1
                    $scope.member_projects.push(makerscienceProjectResults.objects[0])
                else
                    MakerScienceResource.one().get({parent__id : getObjectIdFromURI(team.project)}).then((makerscienceResourceResults) ->
                        if makerscienceResourceResults.objects.length == 1
                            $scope.member_resources.push(makerscienceResourceResults.objects[0])
                    )
            )
        )

        angular.forEach($scope.profile.tags, (taggedItem) ->
            switch taggedItem.tag_type
                when "in" then $scope.preparedInterestTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
                when "sk" then $scope.preparedSkillTags.push({text : taggedItem.tag.name, taggedItemId : taggedItem.id})
        )

        $scope.addTagToProfile = (tag_type, tag) ->
            MakerScienceProfileTaggedItem.one().customPOST({tag : tag.text}, "makerscienceprofile/"+$scope.profile.id+"/"+tag_type, {})

        $scope.removeTagFromProfile = (tag) ->
            MakerScienceProfileTaggedItem.one(tag.taggedItemId).remove()

        $scope.updateMakerScienceProfile = (resourceName, resourceId, fieldName, data) ->
            putData = {}
            putData[fieldName] = data
            switch resourceName
                when 'MakerScienceProfile' then MakerScienceProfile.one(resourceId).patch(putData)
                when 'PostalAddress' then PostalAddress.one(resourceId).patch(putData)

        $scope.updateSocialNetworks = (profile) ->
            console.log(profile)
            $scope.updateMakerScienceProfile('MakerScienceProfile', profile.id, 'facebook', profile.facebook)
            $scope.updateMakerScienceProfile('MakerScienceProfile', profile.id, 'twitter', profile.twitter)
            $scope.updateMakerScienceProfile('MakerScienceProfile', profile.id, 'linkedin', profile.linkedin)
            $scope.updateMakerScienceProfile('MakerScienceProfile', profile.id, 'contact_email', profile.contact_email)
    )
)
