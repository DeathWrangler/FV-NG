package Widgets.Windows
{
   import Managers.AnimalSanctuaryManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.SimpleButton;
   import flash.events.Event;
   
   public class AnimalSanctuaryEndWindow extends FarmWindow
   {
      
      private var m_featureName:String;
      
      private const TITLE_TF:String = "title_tf";
      
      public var m_closeBt:SimpleButton;
      
      private var m_okey_bt:FarmAnimatedTextButton;
      
      public function AnimalSanctuaryEndWindow(featureName:String, assetPath:String)
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],"Animal Sanctuary!"));
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window["subtitle_tf"],"Animal Sanctuary is ending, Congratulations on saving the animals!"));
         }
         if(m_window.hasOwnProperty("okay_bt"))
         {
            addWidget(this.m_okey_bt = new FarmAnimatedTextButton(m_window["okay_bt"],"Awesome!",this.onAccept));
         }
      }
      
      public function onAccept(event:Event) : void
      {
         super.close();
      }
      
      private function get manager() : AnimalSanctuaryManager
      {
         return AnimalSanctuaryManager.getInstance();
      }
   }
}

