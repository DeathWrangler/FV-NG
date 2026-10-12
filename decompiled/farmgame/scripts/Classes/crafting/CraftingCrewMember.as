package Classes.crafting
{
   public class CraftingCrewMember
   {
      
      public static const INVALID_RECIPE_ID:String = "-1";
      
      public var m_uid:String;
      
      public var m_timestamp:int;
      
      public var m_recipeId:String;
      
      public var m_ovenSlot:String;
      
      public var m_worldType:String;
      
      public function CraftingCrewMember(uid:String, timestamp:int, recipeId:String, ovenSlot:String, worldType:String)
      {
         super();
         this.m_uid = uid;
         this.m_timestamp = timestamp;
         this.m_recipeId = recipeId;
         this.m_ovenSlot = ovenSlot;
         this.m_worldType = worldType;
      }
   }
}

