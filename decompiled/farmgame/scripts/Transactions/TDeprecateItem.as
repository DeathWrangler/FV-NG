package Transactions
{
   import Classes.ItemInstance;
   import Engine.Classes.WorldObject;
   import Managers.FarmStatsManager;
   
   public class TDeprecateItem extends TWorldState
   {
      
      protected var m_completeCallback:Function = null;
      
      protected var m_newObject:WorldObject = null;
      
      public function TDeprecateItem(oldWorldObj:WorldObject, newWorldObj:WorldObject = null, completeCallBack:Function = null)
      {
         super(oldWorldObj);
         this.m_newObject = newWorldObj;
         this.m_completeCallback = completeCallBack;
      }
      
      override public function perform() : void
      {
         signedWorldAction("deprecate");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var item:ItemInstance = null;
         var reward:Object = null;
         super.onComplete(result);
         if(result != null)
         {
            if(m_object is ItemInstance)
            {
               item = m_object as ItemInstance;
               FarmStatsManager.count(item.getItemName(),"deprecated");
            }
            m_object.detach();
            if(result.giftBoxItems)
            {
               for each(reward in result.giftBoxItems)
               {
                  Global.player.addGift(reward["name"],"0",reward["quantity"]);
               }
            }
            if(this.m_completeCallback != null)
            {
               this.m_completeCallback(m_object,this.m_newObject);
            }
         }
      }
   }
}

