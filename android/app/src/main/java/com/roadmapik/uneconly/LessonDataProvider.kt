package com.roadmapik.uneconly

import android.util.Log
import com.google.gson.GsonBuilder
import com.google.gson.annotations.SerializedName
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path

data class LessonResponse(
        @SerializedName("lessons") val lessons: List<Lesson>
)

// Retrofit interface for API calls
interface DataProvider {
    @GET("group/{groupId}/lessons/next")
    fun fetchData(@Path("groupId") groupId: Int): Call<LessonResponse>
}


// Implementing the ServerLessonDataProvider
class ServerLessonDataProvider(baseURL: String) {
    private val dataProvider: DataProvider

    init {
        val gson = GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss").create()

        val retrofit = Retrofit.Builder()
                .baseUrl(baseURL)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .build()

        dataProvider = retrofit.create(DataProvider::class.java)
    }

    fun fetchData(groupId: Int, completion: (Lesson?) -> Unit) {
//        completion(Lesson(name = "Lesson name", start = Date(), end = Date(), professor = "123", location = "Lesson location"))
//        return

        dataProvider.fetchData(groupId).enqueue(object : Callback<LessonResponse> {
            override fun onResponse(call: Call<LessonResponse>, response: Response<LessonResponse>) {
                if (response.isSuccessful) {
                    // Assuming you want the first lesson in the list
                    val lessons = response.body()?.lessons

                    Log.i("UWidget", lessons.toString())

                    completion(lessons?.firstOrNull())
                } else {
                    println("Server response error")
                    completion(null)
                }
            }

            override fun onFailure(call: Call<LessonResponse>, t: Throwable) {
                println("Error fetching data: ${t.message}")
                completion(null)
            }
        })
    }
}
