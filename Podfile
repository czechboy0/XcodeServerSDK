
use_frameworks!

def utils
	pod 'BuildaUtils', '0.1.0'
	pod 'ReactiveCocoa', '4.0.2-alpha-1'
end

def tests
	pod 'DVR', :git => "https://github.com/czechboy0/DVR.git", :tag => "v0.0.5-czechboy0"
	pod 'Nimble', '2.0.0-rc.3'
end

target 'XcodeServerSDK' do
	utils
end

target 'XcodeServerSDKTests' do
	utils
	tests
end
