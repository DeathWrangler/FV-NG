package Classes.Growable
{
   import Classes.GrowableAnimalItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import flash.events.EventDispatcher;
   
   public class GrowableUIHelper extends EventDispatcher
   {
      
      public function GrowableUIHelper()
      {
         super();
      }
      
      public static function promptAndFeedConsumable(growableResource:IGrowableResource, callback:Function, buy:Boolean = false, showPrompt:Boolean = false) : void
      {
         var frictionlessCallbackWrapper:Function = null;
         var growableItem:GrowableAnimalItem = null;
         var failureCallbackWrapper:Function = function():void
         {
            callback({
               "complete":false,
               "stage":growableResource.currentVisibleStageName,
               "frictionlessGranted":false
            });
         };
         frictionlessCallbackWrapper = function(data:Object):void
         {
            data.frictionlessGranted = true;
            callback(data);
         };
         if(Global.player.canBuyCash(growableResource.consumableCash))
         {
            if(!showPrompt)
            {
               growableResource.feedConsumable(1,frictionlessCallbackWrapper,buy);
            }
            else
            {
               growableItem = growableResource.growableMapResource.getItem() as GrowableAnimalItem;
               UI.displayMessage(ZLocUtils.t("Dialogs","Growable_CashFeedPermissionPrompt",{
                  "cashQuantity":growableResource.consumableCash,
                  "item":ZLocUtils.tk_pk(growableResource.growableMapResource.getItem().friendlyName),
                  "consumable":ZLocUtils.tk_pk(Global.farmGameSettingsManager.getFarmItemByCode(growableItem.growthConsumable).friendlyName)
               }),GenericPopup.TYPE_ACCEPTCANCEL,function(event:GenericPopupEvent):void
               {
                  if(event.button == GenericPopup.YES)
                  {
                     growableResource.feedConsumable(1,frictionlessCallbackWrapper,buy);
                  }
                  else
                  {
                     failureCallbackWrapper();
                  }
               },"",true);
            }
         }
         else
         {
            failureCallbackWrapper();
         }
      }
      
      public static function promptAndCompleteAnimal(growableResource:IGrowableResource, callback:Function) : void
      {
         if(Global.player.canBuyCash(growableResource.completionCash))
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","Growable_CompleteNowPrompt",{
               "cashQuantity":growableResource.completionCash,
               "item":ZLocUtils.tk_pk(growableResource.growableMapResource.getItem().friendlyName)
            }),GenericPopup.TYPE_ACCEPTCANCEL,function(event:GenericPopupEvent):void
            {
               if(event.button == GenericPopup.YES)
               {
                  growableResource.feedConsumable(growableResource.completionCount,callback,true);
               }
            },"",true);
         }
      }
   }
}

