package Widgets.Windows
{
   import Managers.AnimalSanctuaryV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   
   public class AnimalSanctuaryV2RewardWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private const TITLE_TF:String = "title_tf";
      
      public var m_closeBt:SimpleButton;
      
      private var m_okey_bt:FarmAnimatedTextButton;
      
      private var m_hover_mc:ZwFrame;
      
      private var m_check0_mc:MovieClip;
      
      private var m_check1_mc:MovieClip;
      
      private var m_check2_mc:MovieClip;
      
      private var m_check3_mc:MovieClip;
      
      public function AnimalSanctuaryV2RewardWindow(featureName:String, assetPath:String)
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Animal Sanctuary !"));
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],"Protect these Sanctuaries to get them as rewards!"));
         }
         if(m_window.hasOwnProperty("hover_mc"))
         {
            addWidget(this.m_hover_mc = new ZwFrame(m_window["hover_mc"]),true);
            this.m_hover_mc.visible = true;
            this.m_hover_mc.attachTooltip(new FarmTextTooltip("Wildlife Saviour Pegacorn"));
         }
         if(m_window.hasOwnProperty("check0_mc"))
         {
            this.m_check0_mc = m_window["check0_mc"] as MovieClip;
            this.m_check0_mc.visible = this.manager.isAnimalCompleted(0);
         }
         if(m_window.hasOwnProperty("check1_mc"))
         {
            this.m_check1_mc = m_window["check1_mc"] as MovieClip;
            this.m_check1_mc.visible = this.manager.isAnimalCompleted(1);
         }
         if(m_window.hasOwnProperty("check2_mc"))
         {
            this.m_check2_mc = m_window["check2_mc"] as MovieClip;
            this.m_check2_mc.visible = this.manager.isAnimalCompleted(2);
         }
         if(m_window.hasOwnProperty("check3_mc"))
         {
            this.m_check3_mc = m_window["check3_mc"] as MovieClip;
            this.m_check3_mc.visible = this.manager.isAnimalCompleted(3);
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(this.m_okey_bt = new FarmAnimatedTextButton(m_window["okay_bt"],"Awesome!",this.onAccept));
         }
      }
      
      public function onAccept(event:Event) : void
      {
         this.manager.mainWindow.untintWindow();
         this.manager.mainWindow.enableInput = true;
         super.close();
      }
      
      override public function close() : void
      {
         this.manager.mainWindow.untintWindow();
         this.manager.mainWindow.enableInput = true;
         super.close();
      }
      
      private function get manager() : AnimalSanctuaryV2Manager
      {
         return AnimalSanctuaryV2Manager.getInstance();
      }
   }
}

