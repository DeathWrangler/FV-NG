package Classes
{
   import Classes.ZItem.FarmItem;
   import DataSources.BaseDataSource;
   
   public class SuperCropRequirement extends ItemRequirement
   {
      
      private var m_masteryRequirement:MasteryRequirement;
      
      private var m_numFriendsRequired:int;
      
      public function SuperCropRequirement(xml:XML, item:FarmItem, dataSource:BaseDataSource = null)
      {
         super(xml,item,dataSource);
         this.m_masteryRequirement = new MasteryRequirement(xml,item,dataSource);
         if(m_dataSource)
         {
            this.m_numFriendsRequired = m_dataSource.getInt("amount");
         }
         else
         {
            this.m_numFriendsRequired = m_xml.@amount;
         }
      }
      
      override public function check() : Boolean
      {
         return this.m_masteryRequirement.check() && Global.player.isSuperCropUnlocked(m_item.code) || Global.player.hasSeed(m_item.name);
      }
      
      public function get level() : uint
      {
         return this.m_masteryRequirement.level;
      }
      
      public function get masteryCropName() : String
      {
         return this.m_masteryRequirement.masteryCropName;
      }
      
      public function get friendsRequired() : int
      {
         return this.m_numFriendsRequired;
      }
   }
}

