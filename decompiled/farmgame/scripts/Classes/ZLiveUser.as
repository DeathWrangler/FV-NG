package Classes
{
   public class ZLiveUser
   {
      
      private var m_uid:String = "";
      
      private var m_masterId:String = "";
      
      private var m_firstName:String = "";
      
      private var m_lastName:String = "";
      
      private var m_name:String = "";
      
      private var m_pic:String = "";
      
      private var m_sex:String = "";
      
      public function ZLiveUser()
      {
         super();
      }
      
      public function set uid(value:String) : void
      {
         this.m_uid = value;
      }
      
      public function get uid() : String
      {
         return this.m_uid;
      }
      
      public function set masterId(value:String) : void
      {
         this.m_masterId = value;
      }
      
      public function get masterId() : String
      {
         return this.m_masterId;
      }
      
      public function set firstName(value:String) : void
      {
         this.m_firstName = value;
      }
      
      public function get firstName() : String
      {
         return this.m_firstName;
      }
      
      public function set lastName(value:String) : void
      {
         this.m_lastName = value;
      }
      
      public function get lastName() : String
      {
         return this.m_lastName;
      }
      
      public function set name(value:String) : void
      {
         this.m_name = value;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function set pic(value:String) : void
      {
         this.m_pic = value;
      }
      
      public function get pic() : String
      {
         return this.m_pic;
      }
      
      public function set sex(value:String) : void
      {
         this.m_sex = value;
      }
      
      public function get sex() : String
      {
         return this.m_sex;
      }
   }
}

