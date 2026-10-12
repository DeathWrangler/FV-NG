package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Managers.TurtleInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.events.Event;
   
   public class TurtleInnovationTileUnlockWindow extends FarmWindow
   {
      
      protected var m_featureName:String;
      
      protected var m_shrineName:String;
      
      public function TurtleInnovationTileUnlockWindow(featureName:String, shrineName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         this.m_shrineName = shrineName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var shrine:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_shrineName);
         if(m_window.hasOwnProperty("generic_tf"))
         {
            addWidget(new FarmTextField(m_window["generic_tf"],"Congrats!"));
         }
         if(m_window.hasOwnProperty("generic2_tf"))
         {
            addWidget(new FarmTextField(m_window["generic2_tf"],"You\'ve unlocked a shrine in Elemental Harmony!"));
         }
         if(m_window.hasOwnProperty("icon_mc") && Boolean(shrine))
         {
            addWidget(new FarmIcon(m_window["icon_mc"],shrine.imageRelativeUrl("feed")));
         }
         if(m_window.hasOwnProperty("continue_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window["continue_bt"],"Check it out!",this.onButtonClick));
         }
      }
      
      private function onButtonClick(event:Event) : void
      {
         this.close();
         TurtleInnovationManager.getInstance().showMainUI();
      }
   }
}

