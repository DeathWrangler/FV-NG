package Init
{
   import Classes.EmbeddedArt;
   import Classes.FarmMT4DConfig;
   import Display.UI;
   import Engine.Init.InitializationAction;
   import com.troyer.widget.MT4DConfig;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.parser.DialogParser;
   import com.troyer.widget.parser.XMLDialogParser;
   import flash.events.Event;
   
   public class DynamicDialogsInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "4DInit";
      
      public function DynamicDialogsInit()
      {
         super(INIT_ID);
      }
      
      override public function execute() : void
      {
         var warning:String = null;
         MT4DManager.initialize();
         var config:MT4DConfig = new FarmMT4DConfig();
         MT4DManager.getInstance().setConfig(config);
         var parser:DialogParser = XMLDialogParser.getInstance();
         if(GlobalEngine.getFlashVar("debugUseLocalMT4D") == null || Boolean(GlobalEngine.getFlashVar("debugUseLocalMT4D")))
         {
            parser.parse(new EmbeddedArt.DialogData());
            parser.parse(new EmbeddedArt.GreenhouseDialogData());
            parser.parse(new EmbeddedArt.HolidayCountdownDialogData());
            parser.parse(new EmbeddedArt.HolidayCountdown2011DialogData());
            dispatchEvent(new Event(Event.COMPLETE));
         }
         else
         {
            parser.load("dialogs.xml");
            parser.load("4DXML/Greenhouse.xml");
            parser.load("4DXML/Countdown/HolidayCountdown.xml");
            parser.load("4DXML/Countdown/BirthdayCountdown.xml");
            parser.load("4DXML/Countdown/HolidayCountdown2011.xml");
            warning = "--- Using local MT4D dialogs ---\nDON\'T FORGET copy your dialogs.xml & 4DXML directory into your FarmSim/FarmGame/bin-debug folder!";
            UI.displayMessage(warning);
            parser.addEventListener(Event.COMPLETE,this.onComplete);
         }
      }
      
      private function onComplete(event:Event) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function onGetAssetPath(path:String) : String
      {
         if(path.indexOf("http") == -1)
         {
            return Global.getAssetURL(path);
         }
         return Global.getAssetHashPath(path);
      }
      
      public function onUncompressData(event:Event) : *
      {
         return event.target.data;
      }
   }
}

