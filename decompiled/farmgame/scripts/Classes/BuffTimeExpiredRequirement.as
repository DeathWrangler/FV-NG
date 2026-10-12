package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.FarmItemLock;
   import Classes.buffs.BMasteryGeneric;
   import DataSources.BaseDataSource;
   
   public class BuffTimeExpiredRequirement extends ItemRequirement
   {
      
      public function BuffTimeExpiredRequirement(xml:XML, item:FarmItem, dataSource:BaseDataSource = null)
      {
         super(xml,item,dataSource);
      }
      
      override public function check() : Boolean
      {
         var buff:Buff = null;
         var result:Boolean = false;
         var buffName:String = m_item.buff;
         var buffs:Array = Global.player.getBuffsByClass(BMasteryGeneric);
         var buffExpiredCount:int = 0;
         var buffCount:int = 0;
         for each(buff in buffs)
         {
            if(buff.itemName == buffName)
            {
               buffCount++;
               if(buff.isExpired())
               {
                  buffExpiredCount++;
               }
            }
         }
         if(buffExpiredCount >= buffCount)
         {
            result = true;
         }
         return result;
      }
      
      override public function shouldLockGiftbox() : Boolean
      {
         return true;
      }
      
      override public function shouldLockCashItem() : Boolean
      {
         return true;
      }
      
      override public function get identifier() : String
      {
         return FarmItemLock.WORLD;
      }
   }
}

