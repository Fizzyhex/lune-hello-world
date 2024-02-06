--!strict

local stdio = require("@lune/stdio")

type User = {
	id: string,
	username: string,
	userType: UserType,
}

type UserType = "unverified" | "verified" | "nitro"

local USER_TYPES: { UserType } = { "unverified", "verified", "nitro" }

local function canSendMessages(userType: UserType)
	return userType ~= "unverified"
end

local function getMessageLimit(userType: UserType)
	if userType == "unverified" then
		return 0
	elseif userType == "verified" then
		return 100
	elseif userType == "nitro" then
		return math.huge
	end

	error(`Unhandled UserType '{userType}'`)
end

local function canPinMessages(userType: UserType)
	return userType == "nitro"
end

-- please don't use this - use something like https://gist.github.com/jrus/3197011 instead
local guidClock = math.random(0, 0xf)
local function generateGuid()
	guidClock += 1
	return `{tostring(os.clock()):sub(-4):format("%x")}{string.format("%x", guidClock)}`
end

local users: { User } = {
	{
		id = generateGuid(),
		username = "john_unverified",
		userType = "unverified"
	},
	
	{
		id = generateGuid(),
		username = "jane_unverified",
		userType = "verified"
	},
	
	{
		id = generateGuid(),
		username = "graggle_nitro",
		userType = "nitro"
	}
}

local function displayUser(user: User)
	print(`👤 Name: {user.username}`)
	print(`🆔 ID: {user.id}`)
	print(`📋 User type: {user.userType}`)
	print(`- Can send messages? {canSendMessages(user.userType)}`)
	print(`- Can pin messages? {canPinMessages(user.userType)}`)
	print(`- Message limit: {getMessageLimit(user.userType)}`)
end

local function userCreation()
	local username = stdio.prompt("text", "Enter a username: ")
	local userType
	
	while true do
		userType = stdio.prompt("text", `Enter a user type ({table.concat(USER_TYPES, ", ")}): `):lower()
	
		if table.find(USER_TYPES, userType) then
			break
		end
	
		print(`Invalid user type`)
	end

	local newUser: User = {
		id = generateGuid(),
		username = username,
		userType = userType,
	}

	table.insert(users, newUser)
	displayUser(newUser)
end

local function displayUsers()
	for _, user in users do
		displayUser(user)
		print("----------------------------------------")
	end
end

while true do
	local action = stdio.prompt("text", "What would you like to do? (create_user, display_users, exit): "):lower()

	if action == "create_user" then
		userCreation()
	elseif action == "display_users" then
		displayUsers()
	elseif action == "exit" then
		break
	else
		print("Invalid action")
	end
end