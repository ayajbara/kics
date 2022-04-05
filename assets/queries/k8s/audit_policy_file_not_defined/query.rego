package Cx

import data.generic.common as common_lib
import data.generic.k8s as k8sLib

CxPolicy[result] {
	resource := input.document[i]
	metadata := resource.metadata
	specInfo := k8sLib.getSpecInfo(resource)
	types := {"initContainers", "containers"}
	container := specInfo.spec[types[x]][j]
	common_lib.inArray(container.command, "kube-apiserver")
	not k8sLib.startWithFlag(container, "--audit-policy-file")

	result := {
		"documentId": input.document[i].id,
		"searchKey": sprintf("metadata.name={{%s}}.%s.%s.name={{%s}}.command", [metadata.name, specInfo.path, types[x], container.name]),
		"issueType": "MissingAttribute",
		"keyExpectedValue": "--audit-policy-file flag should be defined",
		"keyActualValue": "--audit-policy-file is not defined",
		"searchLine": common_lib.build_search_line(split(specInfo.path, "."), [types[x], j, "command"]),
	}
}

CxPolicy[result] {
	resource := input.document[i]
	metadata := resource.metadata
	specInfo := k8sLib.getSpecInfo(resource)
	types := {"initContainers", "containers"}
	container := specInfo.spec[types[x]][j]
	common_lib.inArray(container.command, "kube-apiserver")
	k8sLib.startWithFlag(container, "--audit-policy-file")
	path := getFlagPath(container, "--audit-policy-file")
    not hasPolicyFile(input, path)


	result := {
		"documentId": input.document[i].id,
		"searchKey": sprintf("metadata.name={{%s}}.%s.%s.name={{%s}}.command", [metadata.name, specInfo.path, types[x], container.name]),
		"issueType": "IncorrectValue",
		"keyExpectedValue": "--audit-policy-file flag should have a valid file",
		"keyActualValue": "--audit-policy-file does not have a valid file",
		"searchLine": common_lib.build_search_line(split(specInfo.path, "."), [types[x], j, "command"]),
	}
}

getFlagPath(container, flag) = path{
	path:= startsWithGetPath(container.command, flag)
} else = path{
	path:= startsWithGetPath(container.args, flag)
}

startsWithGetPath(arr, item) = path {
    startswith(arr[i], item)
	path := split(arr[i], "=")[1]
}

hasPolicyFile(inputData, path){
	inputData.document[i].kind == "Policy"
    inputData.document[i].file == path
}
