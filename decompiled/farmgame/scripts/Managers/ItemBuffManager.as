package Managers
{
   import Classes.ItemBuff;
   
   public class ItemBuffManager
   {
      
      private static var m_instance:ItemBuffManager;
      
      private static var m_allowInstantiation:Boolean;
      
      private var m_itemBuffs:Object = new Object();
      
      public function ItemBuffManager()
      {
         super();
         if(!m_allowInstantiation)
         {
            throw new Error("Error: Instantiation failed: Use ItemBuffManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : ItemBuffManager
      {
         if(m_instance == null)
         {
            m_allowInstantiation = true;
            m_instance = new ItemBuffManager();
            m_allowInstantiation = false;
         }
         return m_instance;
      }
      
      public function loadObject(data:Object) : void
      {
         var index:String = null;
         var itemBuffData:Object = null;
         var itemBuff:Object = null;
         this.m_itemBuffs = new Object();
         if(Boolean(data) && Boolean(data.itemBuffs))
         {
            for(index in data.itemBuffs)
            {
               this.m_itemBuffs[index] = new Array();
               for each(itemBuffData in data.itemBuffs[index])
               {
                  itemBuff = new Object();
                  itemBuff.buffName = itemBuffData.buffName;
                  itemBuff.startTime = itemBuffData.startTime;
                  this.m_itemBuffs[index].push(itemBuff);
               }
            }
         }
      }
      
      public function getItemBuff(buffName:String, buffItemCode:String) : Array
      {
         var data:Object = null;
         var result:Array = new Array();
         if(this.m_itemBuffs[buffItemCode])
         {
            for each(data in this.m_itemBuffs[buffItemCode])
            {
               if(data.buffName == buffName)
               {
                  result.push(new ItemBuff(buffName,buffItemCode,data.startTime));
               }
            }
         }
         return result;
      }
      
      public function addItemBuff(itemBuff:ItemBuff) : void
      {
         var itemCode:String = itemBuff.buffItemCode;
         if(!this.m_itemBuffs[itemCode])
         {
            this.m_itemBuffs[itemCode] = new Array();
         }
         var itemBuffData:Object = new Object();
         itemBuffData.buffName = itemBuff.buffName;
         itemBuffData.startTime = itemBuff.startTime;
         this.m_itemBuffs[itemCode].push(itemBuffData);
      }
   }
}

