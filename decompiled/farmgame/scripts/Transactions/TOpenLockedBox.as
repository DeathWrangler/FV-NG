package Transactions
{
   import Classes.LootableDecoration;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.LockedBoxPopup;
   import Display.UI;
   import gs.TweenLite;
   
   public class TOpenLockedBox extends TOpenLootItem
   {
      
      protected var m_callbackCloseFunction:Function = null;
      
      protected var m_callbackFailedFunction:Function = null;
      
      public function TOpenLockedBox(lootItem:LootableDecoration, userID:String, passCode:String, callbackFailedFunction:Function, callbackCloseFunction:Function)
      {
         super(lootItem);
         m_lootItem.centerOn();
         this.m_callbackFailedFunction = callbackFailedFunction;
         this.m_callbackCloseFunction = callbackCloseFunction;
         m_params = new Object();
         m_params["isGift"] = false;
         m_params["userID"] = userID;
         m_params["passCode"] = passCode;
      }
      
      override protected function onComplete(result:Object) : void
      {
         var itemName:String = null;
         m_popup.close();
         if(result)
         {
            if(result.item)
            {
               itemName = result.item.toString();
               Global.player.addGift(itemName);
               m_wonItemName = itemName;
               m_lootItem.detach();
               TweenLite.to(this,0.2,{
                  "m_dummy":0,
                  "onComplete":startMCPlaying
               });
               if(this.m_callbackCloseFunction != null)
               {
                  this.m_callbackCloseFunction(null);
               }
            }
            else if(result.invalid)
            {
               if(this.m_callbackFailedFunction != null)
               {
                  this.m_callbackFailedFunction();
               }
            }
            else if(result.error)
            {
               if(this.m_callbackFailedFunction != null)
               {
                  this.m_callbackFailedFunction(false);
               }
               UI.displayMessage(ZLocUtils.t("Dialogs",m_lootItem.itemName + "_" + result.error),0,null,"",true);
            }
         }
      }
      
      override protected function onMCFinishPlaying() : Boolean
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(m_wonItemName);
         UI.displayPopup(new LockedBoxPopup(null,item));
         return false;
      }
   }
}

