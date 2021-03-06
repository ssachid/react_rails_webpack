class ReactExampleController < ApplicationController
  def greeting
    @props_for_hello_component = { details: 'My initial greeting was set with getInitialState in the client/src/components/Hello.jsx file.' }
    @props_for_hello_with_redux_component = { details: 'My initial greeting was set with initialState in the client/src/redux/reducer.js file.' }
  end
end
