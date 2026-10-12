package Classes.UGC
{
   public class UGCItemData
   {
      
      private var m_stateMap:Object;
      
      public function UGCItemData()
      {
         super();
         this.m_stateMap = {};
      }
      
      public function loadData(data:Object, clean:Boolean = false) : void
      {
         var ugcState:UGCItemState = null;
         var uuid:String = null;
         if(clean)
         {
            this.m_stateMap = {};
         }
         if(data)
         {
            for(uuid in data)
            {
               try
               {
                  ugcState = UGCItemState.createFromServerState(data[uuid]);
                  if(ugcState.hasUUID())
                  {
                     if(!this.addUGCItemState(ugcState))
                     {
                        GlobalEngine.error("UGC","UGCItemData#loadData: Failed to add UGCItemState for uuid=" + ugcState.uuid);
                     }
                  }
                  else if(ugcState.hasItemCode())
                  {
                     if(!this.addTempUGCItemState(ugcState))
                     {
                        GlobalEngine.error("UGC","UGCItemData#loadData: Failed to add temp UGCItemState for itemCode=" + ugcState.itemCode);
                     }
                  }
                  else
                  {
                     GlobalEngine.error("UGC","UGCItemData#loadData: Failed to add state, no uuid or item code");
                  }
               }
               catch(err:Error)
               {
                  GlobalEngine.error("UGC","UGCItemData#loadData: error creating new UGCItemState. Message = " + err.message);
               }
            }
         }
      }
      
      public function addUGCItemState(itemState:UGCItemState) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(itemState) && itemState.isValid())
         {
            this.m_stateMap[itemState.uuid] = itemState;
            result = true;
         }
         else
         {
            GlobalEngine.error("UGC","UGCItemData#addUGCItemState: add failed, null or invalid itemState");
         }
         return result;
      }
      
      public function getStateByUUID(uuid:String) : UGCItemState
      {
         var result:UGCItemState = null;
         if(this.m_stateMap.hasOwnProperty(uuid))
         {
            result = this.m_stateMap[uuid] as UGCItemState;
         }
         return result;
      }
      
      public function addTempUGCItemState(itemState:UGCItemState) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(itemState) && itemState.isValid())
         {
            this.m_stateMap[itemState.itemCode] = itemState;
            result = true;
         }
         else
         {
            GlobalEngine.error("UGC","UGCItemData#addTemporaryUGCState: add failed, null or invalid itemState");
         }
         return result;
      }
      
      public function getTempStateByItemCode(itemCode:String) : UGCItemState
      {
         var result:UGCItemState = null;
         if(this.m_stateMap.hasOwnProperty(itemCode))
         {
            result = this.m_stateMap[itemCode] as UGCItemState;
         }
         return result;
      }
      
      public function removeTempUGCItemState(itemCode:String) : void
      {
         if(Boolean(itemCode) && this.m_stateMap.hasOwnProperty(itemCode))
         {
            delete this.m_stateMap[itemCode];
         }
      }
   }
}

