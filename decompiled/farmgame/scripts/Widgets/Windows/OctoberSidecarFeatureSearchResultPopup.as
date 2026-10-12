package Widgets.Windows
{
   import Managers.OctoberSidecarFeatureManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class OctoberSidecarFeatureSearchResultPopup extends FarmWindowWithTutorial
   {
      
      private static const FEATURE_NAME:String = "GilroysParade";
      
      private var m_featureName:String = null;
      
      private var m_cluesCount:int = 0;
      
      private var m_title_tf:ZwTextField;
      
      private var m_subtext_tf:ZwTextField;
      
      private var m_consumable_mc:MovieClip;
      
      private var m_cluecount_tf:ZwTextField;
      
      private var m_accept_bt:FarmAnimatedTextButton;
      
      public function OctoberSidecarFeatureSearchResultPopup(featureName:String = "GilroysParade", assetUrl:String = null, partsFound:int = 0)
      {
         this.m_featureName = featureName;
         this.m_cluesCount = partsFound;
         super(FEATURE_NAME,assetUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.setWindowPosition();
         if(m_window.hasOwnProperty("title_tf"))
         {
            this.m_title_tf = new ZwTextField(m_window["title_tf"]);
            this.m_title_tf.text = this.m_cluesCount > 0 ? "Wohoo!" : "Oh no!";
            this.m_title_tf.visible = true;
         }
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            this.m_subtext_tf = new ZwTextField(m_window["subtext_tf"]);
            this.m_subtext_tf.text = this.m_cluesCount > 0 ? this.getRandomFoundText() : this.getRandomNotFoundText();
            this.m_subtext_tf.visible = true;
         }
         if(m_window.hasOwnProperty("consumables"))
         {
            this.m_consumable_mc = m_window["consumables"] as MovieClip;
            if(this.m_consumable_mc.hasOwnProperty("consumablecount_tf"))
            {
               this.m_cluecount_tf = new ZwTextField(this.m_consumable_mc["consumablecount_tf"],"x" + this.m_cluesCount.toString());
               this.m_cluecount_tf.visible = true;
            }
            this.m_consumable_mc.visible = true;
         }
         if(m_window.hasOwnProperty("accept_bt"))
         {
            this.m_accept_bt = new FarmAnimatedTextButton(m_window["accept_bt"],"",this.onAcceptClick);
            this.m_accept_bt.text = this.m_cluesCount > 0 ? "Great!" : "Okay!";
            this.m_accept_bt.visible = true;
         }
      }
      
      private function onAcceptClick(e:Event = null) : void
      {
         this.close();
      }
      
      private function getRandomFoundText() : String
      {
         var result:String = "Fantastic! We found more clues!";
         var textOptions:Array = new Array("Amazing! Maggie found new clues!","Maggie can use these clues to find the stolen items!","Fantastic! Maggie found more clues!","Maggie found more clues for the investigation!");
         var randomIndex:int = int(Math.floor(Math.random() * 4));
         if(randomIndex >= 0 && randomIndex <= 3)
         {
            result = textOptions[randomIndex];
         }
         return result;
      }
      
      private function getRandomNotFoundText() : String
      {
         var result:String = "Oh no! I didn’t find any clues this time";
         var textOptions:Array = new Array("Maggie couldn’t find any clues this time","The thief is being extra careful. Let’s look for the clues again!","Oops, Maggie didn’t find any clues!","No clues! Looks like Maggie needs to explore new lands");
         var randomIndex:int = int(Math.floor(Math.random() * 4));
         if(randomIndex >= 0 && randomIndex <= 3)
         {
            result = textOptions[randomIndex];
         }
         return result;
      }
      
      private function setWindowPosition() : void
      {
         if(m_window)
         {
            m_window.x += 60;
         }
      }
      
      private function get manager() : OctoberSidecarFeatureManager
      {
         return OctoberSidecarFeatureManager.getInstance(FEATURE_NAME);
      }
      
      override public function close() : void
      {
         if(this.manager.m_mainWindow)
         {
            this.manager.m_mainWindow.enableInput = true;
            this.manager.m_mainWindow.untintWindow();
         }
         super.close();
      }
   }
}

