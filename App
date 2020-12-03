import bluetooth
import thingspeak
import kivy
from kivy.app import App
from kivy.uix.label import Label
from kivy.uix.gridlayout import GridLayout
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.textinput import TextInput
from kivy.uix.button import Button
from kivy.uix.image import Image
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.core.audio import SoundLoader
from kivy.clock import Clock

class PromptPage(FloatLayout):                                                                                                                                                                                                                                                                                                                                          
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.size=(300,300)                                                                                                                                                         
        image = Image(source = 'AppBackground.jpg', size_hint=(1,1))
        self.add_widget(image)
        self.First_Page_Welcome_Prompt = Label(text = "Thank You for using the UpRight App and Device", font_size=20, size_hint=(.6, .2), pos = (100,350))                     
        self.First_Time_User_Button = Button(text = "Click here to start the set up for UpRight Device",on_press=self.first_time_user_button, size_hint=(.6, .05), pos=(100,50), background_color = (0,0,.7,0))
        self.Returning_User_Button = Button(text = "Click here to monitor the UpRight Device",on_press=self.returning_user_button, size_hint=(.6,.05), pos=(100,0), background_color = (0,0,.7,0))
        self.add_widget(self.First_Page_Welcome_Prompt)
        self.add_widget(self.First_Time_User_Button)
        self.add_widget(self.Returning_User_Button)


    def first_time_user_button(self, instance):                                                                                                 
        upright_app.screen_manager.current = "Info"

    def returning_user_button(self,instance):   
        upright_app.screen_manager.current = "Monitor"

class InfoPage(FloatLayout):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.size=(300,300)
        string1 = "Please set up a free thingspeak account by going to thingspeak.com\n"
        string2 = "As you set up your channel, write down your channel ID, write and read API keys\n"
        string3 = "*They will be different than the ones in the example"
        self.SetUp_Button = Button(text="Click here after you set up your account", on_press=self.set_up_input,size_hint=(.75,.05),pos=(100,30), background_color=(0,0,.7,0))
        image = Image(source = 'AppBackground.jpg', size_hint=(1,1))
        self.add_widget(image)
        self.add_widget(self.SetUp_Button)
        self.message  = Label(text = string1+string2+string3, size_hint=(.75,.2),pos = (0,-200))
        self.add_widget(self.message)                
        test_image = Image(source='Thingspeak_instructions.jpeg',pos=(0,75))
        self.add_widget(test_image)

    def set_up_input(self, instance):
        upright_app.screen_manager.current = "Set Up Input"

class MonitorPage(FloatLayout):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.size = (300,300)
        self.ChannelID = TextInput(text = "Enter Channel ID here", size_hint=(.5,.2), pos=(150,150))
        self.ChannelReadKey = TextInput(text = "Enter Channel Read Key here", size_hint=(.5,.2), pos=(150,100))
        self.monitor_channel_button = Button(text = 'Start Monitoring', on_press=self.monitor_channel, size_hint=(.5,.2), pos=(150,0), background_color=(0,0,.7,0))
        image = Image(source = 'AppBackground.jpg', size_hint=(1,1))
        self.add_widget(image)
        self.add_widget(self.ChannelID)
        self.add_widget(self.ChannelReadKey)
        self.add_widget(self.monitor_channel_button)

    def monitor_channel(self, instance):
        Clock.schedule_interval(self.check_ifAlert, 20)

    def check_ifAlert(self,*args):
        channel = thingspeak.Channel(id = eval(self.ChannelID.text), api_key = self.ChannelReadKey.text)
        data = channel.get_field(field="field1")
        data = eval(data)
        entry_id = len(data["feeds"])
        recent_message = data["feeds"][entry_id-1]["field1"]
        recent_message = eval(recent_message)
        self.remove_widget(self.ChannelID)
        self.remove_widget(self.ChannelReadKey)
        self.monitor_channel_button.text = "Actively Monitoring"
        self.monitor_channel_button.font_size = 14
        self.monitor_channel_button.background_color = (0,0,.7,0)
        if recent_message == 1:
            sound = SoundLoader.load("test.wav")
            sound.play()
            self.monitor_channel_button.text = "Alert! Let's check on the device"
            self.monitor_channel_button.font_size = 30
        return
        

class SetUpPage(FloatLayout):    #lets turn this into float real quick
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.size = (300,300)
        
        self.NetworkName = TextInput(text = "Enter Network Name here", size_hint=(.5,.2), pos=(150,250))
        self.NetworkPassword = TextInput(text = 'Enter Network Password here', size_hint=(.5,.2), pos = (150,200))
        self.ChannelID = TextInput(text = "Enter Channel ID here", size_hint = (.5,.2), pos=(150,150))
        self.ChannelWriteKey = TextInput(text = "Enter Channel Write Key here", size_hint=(.5,.2), pos=(150,100))
        submit = Button(text = 'Complete Set Up', on_press=self.set_up_submission, size_hint=(.5, .2), pos=(150,10), background_color=(0,0,.7,0))
        image = Image(source = 'AppBackground.jpg', size_hint=(1,1))
        self.add_widget(image)
        self.add_widget(self.NetworkName)
        self.add_widget(self.NetworkPassword)
        self.add_widget(self.ChannelID)
        self.add_widget(self.ChannelWriteKey)
        self.add_widget(submit)
        
        message = "Please make sure your phones bluetooth connection is on and you connect to the UpRight Device listed\n"
        message1 = "After clicking 'Complete Set Up' wait a moment for the UpRight Device to connect to the internet and thingspeak\n"
        message2 = "Make sure your UpRight device is placed on a flat surface"
        self.message1 = Label(text = message+message1+message2,font_size=10, size_hint = (.5,.2), pos=(150,350))
        self.add_widget(self.message1)

    def set_up_submission(self, instance):
        NetworkName = self.NetworkName.text
        NetworkPassword = self.NetworkPassword.text
        ChannelID = self.ChannelID.text
        ChannelWriteKey = self.ChannelWriteKey.text
        Clock.schedule_once(self.bluetooth,1)
        upright_app.screen_manager.current = "Monitor"

    def bluetooth(self, *args):
        #target_address = "FC:F5:C4:01:19:3A"   testing microcontroller
        target_address = "FC:F5:C4:01:1A:BE"    #microcontroller used for demo and submission
        nearby_devices = bluetooth.discover_devices()

        print("addresses found: \n")
        for bdaddr in nearby_devices:
            if bdaddr == target_address:
                print("{}".format(target_name))
                break

        if bdaddr is not None:
            client_sock = bluetooth.BluetoothSocket(bluetooth.RFCOMM)
            port = 1
            client_sock.connect((target_address, port))
            print("Accepted connection from: {}".format(target_address))

            message = [self.NetworkName.text, self.NetworkPassword.text, self.ChannelID.text, self.ChannelWriteKey.text]
            new_message = self.NetworkName.text+"+"+self.NetworkPassword.text+"+"+self.ChannelID.text+"+"+self.ChannelWriteKey.text+" #"

            print("sending new message: {}".format(new_message))
            encoded_message = new_message.encode('utf-8')
            client_sock.send(encoded_message)
                
            client_sock.close()

        else:
            print("could not find target bluetooth device nearby")
            

class UpRightApp(App):
    def build(self):
        # We are going to use screen manager, so we can add multiple screens
        # and switch between them
        self.screen_manager = ScreenManager()

        # Initial, connection screen (we use passed in name to activate screen)
        # First create a page, then a new screen, add page to screen and screen to screen manager
        self.Prompt_page = PromptPage()
        screen = Screen(name='Connect')
        screen.add_widget(self.Prompt_page)
        self.screen_manager.add_widget(screen)

        # same thing for Info page
        self.info_page = InfoPage()
        screen = Screen(name='Info')
        screen.add_widget(self.info_page)
        self.screen_manager.add_widget(screen)

        # Monitor page
        self.monitor_page = MonitorPage()
        screen = Screen(name='Monitor')
        screen.add_widget(self.monitor_page)
        self.screen_manager.add_widget(screen)

        #Set Up Input page
        self.setup_page = SetUpPage()
        screen = Screen(name="Set Up Input")
        screen.add_widget(self.setup_page)
        self.screen_manager.add_widget(screen)

        return self.screen_manager


if __name__ == "__main__":
    upright_app = UpRightApp()
    upright_app.run()
