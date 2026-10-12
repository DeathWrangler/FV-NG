package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import flash.events.Event;
   
   public class NPCRewardGrantWindow extends GenericSingleRewardPopup
   {
      
      public function NPCRewardGrantWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null)
      {
         super(dialogAsset,featureName,rewardItem,buttonCallback,dialogBackground);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         this.setCloseButtonVisible(false);
      }
   }
}

