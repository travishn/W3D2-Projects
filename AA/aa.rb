require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database 
  include Singleton 
  
  def initialize
    super('aa2.db')
    self.type_translation = true 
    self.results_as_hash = true 
  end 

end

class User 
  attr_accessor :fname, :lname
  attr_reader :id 
  
  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM 
        users 
      WHERE 
        id = ?
    SQL
    
    return nil if user.empty?
    User.new(user[0])
  end 
  
  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ?
        AND lname = ?
    SQL
    
    return nil if user.empty?
    User.new(user[0])
  end 
  
  def authored_questions
    questions = Question.find_by_author_id(id)
  end 
  
  def authored_replies
    replies = Reply.find_by_user_id(id)
  end 
  
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
  
  def followed_questions
    QuestionFollows.followed_questions_for_user_id(id)
  end
  
  def liked_questions 
    QuestionLike.liked_questions_for_user_id(id)
  end  
   
  def average_karma
    average = QuestionsDatabase.instance.execute(<<-SQL) 
      SELECT 
        CAST(COUNT(question_likes.user_id) AS FLOAT)/COUNT(DISTINCT questions.id) 
      FROM 
        questions 
      JOIN
        question_likes
      ON
        questions.author_id = question_likes.user_id
      GROUP BY
        questions.id
      HAVING
        author_id = id
  SQL
  end 
end

class Question
  attr_reader :id
  attr_accessor :title, :body, :author_id
  
  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM 
        questions 
      WHERE 
        id = ?
    SQL
    
    return nil if question.empty?
    Question.new(question[0])
  end
  
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
  
  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM 
        questions 
      WHERE 
        author_id = ?
    SQL
    
    return nil if question.empty?
    questions.map { |question| Question.new(question) }
  end 
  
  def author 
    user = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM 
        users 
      WHERE 
        author_id = users.id 
    SQL
    
    return nil if user.empty?
    User.new(user[0])
  end
  
  def replies
    Reply.find_by_question_id(id)
  end
  
  def followers 
    QuestionFollow.followers_for_question_id(id)
  end
  
  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end
  
  def likers
    QuestionLike.likers_for_question_id(id)
  end
  
  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end
  
  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
  
   
end


# class QuestionFollows
#   attr_reader :id
#   attr_accessor :user_id, :question_id
# 
#   def self.find_by_id(id)
#     follow = QuestionsDatabase.instance.execute(<<-SQL, id)
#       SELECT
#         *
#       FROM 
#         question_follows 
#       WHERE 
#         id = ?
#     SQL
# 
#     return nil if follow.empty?
#     QuestionFollows.new(follow[0])
#   end
# 
#   def initialize(options)
#     @id = options['id']
#     @question_id = options['question_id']
#     @user_id = options['user_id']
#   end
# end


class Reply
  attr_reader :id, :body
  attr_accessor :parent_id, :question_id, :user_id
  
  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM 
        replies
      WHERE 
        id = ?
    SQL
    
    return nil if reply.empty?
    reply.map { |datum| Reply.new(datum) }
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @parent_id = options['parent_id']
    @body = options['body']
  end
  
  def self.find_by_user(user_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM 
        replies
      WHERE 
        user_id = ?
    SQL
    
    return nil if reply.empty?
    Reply.new(reply[0])
  end 
  
  def self.find_by_user(question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM 
        replies
      WHERE 
        question_id = ?
    SQL
    
    return nil if reply.empty?
    reply.map { |datum| Reply.new(datum) }
  end 
  
  def author 
    user = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM 
        replies 
      WHERE 
        user_id = users.id 
    SQL
    
    return nil if user.empty?
    User.new(user[0])
  end
  
  def question
    question = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = questions.id
      SQL
      
      return nil if question.empty?
      Question.new(question[0])
  end
  
  def parent_reply
    par_reply = QuestionsDatabase.instance.execute(<<-SQL, parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = parent_id 
      SQL
      
      return nil if par_reply.empty?
      Reply.new(par_reply[0])
  end
  
  def child_replies 
    child_reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = id  
      SQL
      
      return nil if child_reply.empty?
      child_reply.map { |datum| Reply.new(datum) }
  end 
  
  
  
end

class QuestionFollows
  attr_reader :id
  attr_accessor :user_id, :question_id, :follows 
  
  def self.find_by_id(id)
    follow = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM 
        question_follows 
      WHERE 
        id = ?
    SQL
    
    return nil if follow.empty?
    QuestionFollows.new(follow[0])
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @follows = options['follows']
  end
  
  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        fname, lname 
      FROM 
        users
      JOIN
        question_follows ON users.id = question_follows.user_id 
      WHERE
        question_follows.user_id = question_id
    SQL
    
    users.map { |datum| User.new(datum) }
  end
  
  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        questions.id, title, body, author_id
      FROM
        questions
      JOIN question_follows ON questions.id = question_id
      WHERE
        question_follows.user_id = user_id
    SQL
    
    questions.map { |datum| Question.new(datum) }
  end
  
  def self.most_followed_questions(n) 
    questions = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM 
        question_follows 
      JOIN 
        questions ON question_follows.question_id = question.id 
      ORDER BY 
        follows DESC
      LIMIT
        n 
    SQL
  end 
  

end


class QuestionLikes
  attr_reader :id
  attr_accessor :num_likes, :question_id, :user_id
  
  def self.find_by_id(id)
    like = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM 
        question_likes
      WHERE 
        id = ?
    SQL
    
    return nil if like.empty?
    QuestionLikes.new(like[0])
  end
  
  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @num_likes = options['num_likes']
  end
  
  def self.likers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        user_id
      FROM
        question_likes
      WHERE
        question_likes.question_id = question_id
    SQL
  end
  
  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        num_likes
      FROM
        question_likes
      WHERE
        question_likes.question_id = question_id
    SQL
  end
  
  def self.liked_questions_for_user_id(user_id)
    liked_questions = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        question_id
      FROM
        question_likes
      JOIN questions ON question_likes.user_id = questions.author_id 
      WHERE
        num_likes > 0 
    SQL
  end
  
  def self.most_liked_questions(n) 
    questions = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        question_id
      FROM 
        question_likes
      ORDER BY 
        num_likes DESC
      LIMIT
        n 
    SQL
  end 
     
end





  