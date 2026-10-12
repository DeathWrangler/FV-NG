package Classes.crafting
{
   public class CraftTypeState
   {
      
      private var m_craftType:String;
      
      private var m_level:int = 1;
      
      private var m_experience:int = 0;
      
      private var m_specializations:Object;
      
      public function CraftTypeState(craftType:String, level:int = 1, xp:int = 0)
      {
         var specializationId:String = null;
         this.m_specializations = new Object();
         super();
         this.m_craftType = craftType;
         this.m_level = level;
         this.m_experience = xp;
         var specializations:Array = Global.craftConfigSettings.getSpecializations(this.m_craftType);
         for each(specializationId in specializations)
         {
            this.m_specializations[specializationId] = new CraftSpecialization(craftType,specializationId);
         }
      }
      
      public function get craftType() : String
      {
         return this.m_craftType;
      }
      
      public function get level() : int
      {
         return this.m_level;
      }
      
      public function set level(level:int) : void
      {
         this.m_level = level;
      }
      
      public function getSpecialization(specializationId:String) : CraftSpecialization
      {
         var result:CraftSpecialization = null;
         if(this.m_specializations.hasOwnProperty(specializationId))
         {
            result = this.m_specializations[specializationId];
         }
         return result;
      }
      
      public function incrementLevel() : void
      {
         this.m_level += 1;
         var levelInfo:CraftLevel = Global.craftConfigSettings.getCraftLevel(this.m_level);
         if(levelInfo != null && this.m_experience > levelInfo.experience)
         {
            this.m_experience -= levelInfo.experience;
         }
         else
         {
            this.m_experience = 0;
         }
      }
      
      public function get experience() : int
      {
         return this.m_experience;
      }
      
      public function set experience(exp:int) : void
      {
         this.m_experience = exp;
      }
      
      public function addExperience(exp:int) : void
      {
         this.m_experience += exp;
      }
      
      public function getExperienceIncNeededForLevel(level:int) : int
      {
         var levelInfo:CraftLevel = Global.craftConfigSettings.getCraftLevel(level);
         return levelInfo.experience;
      }
      
      public function getFractionalProgessToNextLevel() : Number
      {
         return this.m_experience / this.getExperienceIncNeededForLevel(this.m_level + 1);
      }
   }
}

