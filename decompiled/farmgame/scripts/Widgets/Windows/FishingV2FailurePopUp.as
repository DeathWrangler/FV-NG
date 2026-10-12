package Widgets.Windows
{
   import Managers.FishingV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class FishingV2FailurePopUp extends FarmWindow
   {
      
      private var m_titleTF:ZwTextField;
      
      private var m_retryBT:FarmAnimatedTextButton;
      
      private var m_collectionBT:FarmAnimatedTextButton;
      
      private var m_failSubText:ZwTextField;
      
      private var m_tensionType:int;
      
      public function FishingV2FailurePopUp(assetURL:String, tension:int = 1)
      {
         this.m_tensionType = tension;
         super(assetURL);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window["title_tf"])
         {
            this.m_titleTF = addWidget(new ZwTextField(m_window["title_tf"],"FISHING FAILURE")) as ZwTextField;
            this.m_titleTF.visible = true;
         }
         if(m_window["fail_subtext_tf"])
         {
            this.m_failSubText = addWidget(new ZwTextField(m_window["fail_subtext_tf"],"")) as ZwTextField;
            this.m_failSubText.visible = true;
         }
         if(m_window["collection_bt"])
         {
            this.m_collectionBT = new FarmAnimatedTextButton(m_window["collection_bt"],"",function(event:Event):void
            {
               FishingV2Manager.getInstance().showFishCollectionsWindow();
               close();
            }) as FarmAnimatedTextButton;
            this.m_collectionBT.visible = true;
         }
         if(m_window["retry_bt"])
         {
            this.m_retryBT = new FarmAnimatedTextButton(m_window["retry_bt"],"",function(event:Event):void
            {
               FishingV2Manager.getInstance().openCraftingWindow();
               close();
            }) as FarmAnimatedTextButton;
            if(FishingV2Manager.getInstance().isMasteryTrophyGranted())
            {
               this.m_retryBT.visible = false;
            }
            else
            {
               this.m_retryBT.visible = true;
            }
         }
         if(!FishingV2Manager.isTutorial2Over())
         {
            this.m_retryBT.visible = false;
         }
      }
      
      override protected function afterLoad() : void
      {
         super.afterLoad();
         if(this.m_failSubText)
         {
            if(!this.m_tensionType)
            {
               this.m_failSubText.text = "Unsuccessful! The line broke due to high tension!";
            }
            else
            {
               this.m_failSubText.text = "Unsuccessful! The line tension was low and the fish got away!";
            }
         }
         m_closeButton.visible = false;
      }
   }
}

