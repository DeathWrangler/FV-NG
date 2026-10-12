package Managers.Crafting
{
   import flash.utils.Dictionary;
   
   public class CraftingSkillSummary
   {
      
      private var m_recipeDictionary:Dictionary;
      
      private var m_craftingSkills:Dictionary;
      
      private var m_owner:String;
      
      public function CraftingSkillSummary(owner:String, recipeDictionary:Dictionary, skillDictionary:Dictionary)
      {
         super();
         this.m_owner = owner;
         this.m_craftingSkills = skillDictionary;
         this.m_recipeDictionary = recipeDictionary;
      }
      
      public static function loadFromServerObject(skills:Object) : CraftingSkillSummary
      {
         var recipeId:String = null;
         var cottages:Dictionary = null;
         var skillId:String = null;
         var result:CraftingSkillSummary = null;
         var owner:String = skills.uid;
         var recipes:Dictionary = new Dictionary();
         for(recipeId in skills.recipes)
         {
            recipes[recipeId] = skills.recipes[recipeId];
         }
         cottages = new Dictionary();
         for(skillId in skills.cottages)
         {
            cottages[skillId] = skills.cottages[skillId];
         }
         return new CraftingSkillSummary(owner,recipes,cottages);
      }
      
      public function getLevelForRecipeId(recipeId:String) : int
      {
         var result:int = 0;
         if(this.m_recipeDictionary[recipeId] != null && this.m_recipeDictionary[recipeId].l != null)
         {
            result = int(this.m_recipeDictionary[recipeId].l);
         }
         return result;
      }
      
      public function isActiveParticipantInSkill(skill:String) : Boolean
      {
         var result:Boolean = false;
         if(this.m_craftingSkills[skill] != null && this.m_craftingSkills[skill].a != null)
         {
            result = this.m_craftingSkills[skill].a == 1;
         }
         return result;
      }
      
      public function get owner() : String
      {
         return this.m_owner;
      }
      
      public function get hasValidUser() : Boolean
      {
         return !isNaN(Number(this.m_owner)) && Global.friendManager.getFriendData(this.m_owner) != null;
      }
   }
}

