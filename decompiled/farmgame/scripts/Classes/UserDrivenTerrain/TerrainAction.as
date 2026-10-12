package Classes.UserDrivenTerrain
{
   public class TerrainAction
   {
      
      public var m_actionData:Object = null;
      
      public var m_actionType:int = 0;
      
      public function TerrainAction(actionData:Object, actionType:int)
      {
         super();
         this.m_actionData = actionData;
         this.m_actionType = actionType;
      }
      
      public function get actionType() : int
      {
         return this.m_actionType;
      }
      
      public function get actionData() : Object
      {
         return this.m_actionData;
      }
   }
}

