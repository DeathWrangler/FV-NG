package Transactions
{
   import Classes.MapResource;
   import Classes.util.WorldIdUtil;
   import Engine.Classes.WorldObject;
   
   public class TWorldState extends TFarmTransaction
   {
      
      public static const METHOD_PERFORM_ACTION:String = "performAction";
      
      public static const ACTION_USE:String = "use";
      
      protected static var m_isFirstWorldAction:Boolean = true;
      
      protected var m_save:Object;
      
      protected var m_object:WorldObject = null;
      
      public function TWorldState(worldObj:WorldObject)
      {
         super();
         this.m_object = worldObj;
         if(this.m_object != null && this.m_object.getId() == 0 && !Global.worldManager.isVisiting())
         {
            WorldIdUtil.assignTempIdToWorldObject(worldObj);
         }
         if(worldObj != null)
         {
            this.m_save = worldObj.getSaveObject();
         }
         else
         {
            this.m_save = null;
         }
      }
      
      override public function perform() : void
      {
      }
      
      final public function onMultiComplete(result:Object) : void
      {
         this.onComplete(result.data);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(this.m_object != null && (this.m_object.getId() == 0 || this.m_object.getId() >= WorldIdUtil.TEMP_ID_START) && result.hasOwnProperty("id") && result.id != 0)
         {
            this.m_object.setId(result.id);
         }
         if(Boolean(this.m_object != null) && Boolean(this.m_object as MapResource) && result.hasOwnProperty("storageKey"))
         {
            (this.m_object as MapResource).attachToPersistentData(result.storageKey);
         }
      }
      
      protected function signedWorldAction(actionName:String, ... params) : void
      {
         if(true == m_isFirstWorldAction && actionName != "move")
         {
            m_isFirstWorldAction = false;
            params.push({"firstWA":true});
         }
         signedCall("WorldService." + METHOD_PERFORM_ACTION,actionName,this.m_save,params);
         m_functionName = "WorldService." + METHOD_PERFORM_ACTION + ":" + actionName;
      }
   }
}

